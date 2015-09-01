FROM debian:jessie
MAINTAINER Krzysztof Kardasz <krzysztof@kardasz.eu>

# Update system and install required packages
ENV DEBIAN_FRONTEND noninteractive

# Install git, download and extract Stash and create the required directory layout.
# Try to limit the number of RUN instructions to minimise the number of layers that will need to be created.
RUN apt-get update -qq \
    && apt-get install -y wget curl git unzip \
    && apt-get clean autoclean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

# Download Oracle JDK
ENV ORACLE_JDK_VERSION jdk-8u51
ENV ORACLE_JDK_URL     http://download.oracle.com/otn-pub/java/jdk/8u51-b16/jdk-8u51-linux-x64.tar.gz
RUN mkdir -p /opt/jdk/$ORACLE_JDK_VERSION && \
    wget --header "Cookie: oraclelicense=accept-securebackup-cookie" -O /opt/jdk/$ORACLE_JDK_VERSION/$ORACLE_JDK_VERSION.tar.gz $ORACLE_JDK_URL && \
    tar -zxf /opt/jdk/$ORACLE_JDK_VERSION/$ORACLE_JDK_VERSION.tar.gz --strip-components=1 -C /opt/jdk/$ORACLE_JDK_VERSION && \
    rm /opt/jdk/$ORACLE_JDK_VERSION/$ORACLE_JDK_VERSION.tar.gz && \
    update-alternatives --install /usr/bin/java java /opt/jdk/$ORACLE_JDK_VERSION/bin/java 100 && \
    update-alternatives --install /usr/bin/javac javac /opt/jdk/$ORACLE_JDK_VERSION/bin/javac 100

ENV DOWNLOAD_URL        https://downloads.atlassian.com/software/jira/downloads/atlassian-jira-

# https://confluence.atlassian.com/display/STASH/Stash+home+directory
ENV JIRA_HOME          /var/atlassian/application-data/jira

ENV JAVA_HOME /opt/jdk/$ORACLE_JDK_VERSION
ENV JAVA_OPTS "-Djavax.net.ssl.trustStore=/etc/ssl/certs/java/cacerts -Djavax.net.ssl.trustStorePassword=changeit"

# Use the default unprivileged account. This could be considered bad practice
# on systems where multiple processes end up being executed by 'daemon' but
# here we only ever run one process anyway.
ENV RUN_USER            atlassian
ENV RUN_USER_UID        5000
ENV RUN_GROUP           atlassian
ENV RUN_GROUP_GID       5000

RUN \
    groupadd --gid ${RUN_GROUP_GID} -r ${RUN_GROUP} && \
    useradd -r --uid ${RUN_USER_UID} -g ${RUN_GROUP} ${RUN_USER}

# Install Atlassian Stash to the following location
ENV JIRA_INSTALL_DIR   /opt/atlassian/jira

ENV JIRA_VERSION 6.4.11

RUN mkdir -p                             ${JIRA_INSTALL_DIR} \
    && curl -L --silent                  ${DOWNLOAD_URL}${JIRA_VERSION}.tar.gz | tar -xz --strip=1 -C "$JIRA_INSTALL_DIR" \
    && mkdir -p                          ${JIRA_INSTALL_DIR}/conf/Catalina      \
    && chown -R nobody:nogroup           ${JIRA_INSTALL_DIR}/                   \
    && chmod -R 755                      ${JIRA_INSTALL_DIR}/                   \
    && chmod -R 700                      ${JIRA_INSTALL_DIR}/conf/Catalina      \
    && chmod -R 700                      ${JIRA_INSTALL_DIR}/logs               \
    && chmod -R 700                      ${JIRA_INSTALL_DIR}/temp               \
    && chmod -R 700                      ${JIRA_INSTALL_DIR}/work               \
    && chown -R ${RUN_USER}:${RUN_GROUP} ${JIRA_INSTALL_DIR}/logs               \
    && chown -R ${RUN_USER}:${RUN_GROUP} ${JIRA_INSTALL_DIR}/temp               \
    && chown -R ${RUN_USER}:${RUN_GROUP} ${JIRA_INSTALL_DIR}/work               \
    && chown -R ${RUN_USER}:${RUN_GROUP} ${JIRA_INSTALL_DIR}/conf

# MySQL connector, mail api, activation api
RUN \
    wget --header "Cookie: oraclelicense=accept-securebackup-cookie" -O ${JIRA_INSTALL_DIR}/jaf-1_1_1.zip http://download.oracle.com/otn-pub/java/jaf/1.1.1/jaf-1_1_1.zip && \
    unzip ${JIRA_INSTALL_DIR}/jaf-1_1_1.zip -d ${JIRA_INSTALL_DIR} && \
    mv ${JIRA_INSTALL_DIR}/jaf-1.1.1/activation.jar ${JIRA_INSTALL_DIR}/lib/ && \
    rm -rf ${JIRA_INSTALL_DIR}/jaf-1.1.1 ${JIRA_INSTALL_DIR}/jaf-1_1_1.zip && \
    wget -O ${JIRA_INSTALL_DIR}/mail-1.5.4.jar http://java.net/projects/javamail/downloads/download/javax.mail.jar && \
    mv ${JIRA_INSTALL_DIR}/mail-1.5.4.jar ${JIRA_INSTALL_DIR}/lib/ && \
    wget -O ${JIRA_INSTALL_DIR}/mysql-connector-java-5.1.36.tar.gz http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.36.tar.gz && \
    tar xzf ${JIRA_INSTALL_DIR}/mysql-connector-java-5.1.36.tar.gz -C ${JIRA_INSTALL_DIR} && \
    mv ${JIRA_INSTALL_DIR}/mysql-connector-java-5.1.36/mysql-connector-java-5.1.36-bin.jar ${JIRA_INSTALL_DIR}/lib/ && \
    rm -rf ${JIRA_INSTALL_DIR}/mysql-connector-java-5.1.36.tar.gz ${JIRA_INSTALL_DIR}/mysql-connector-java-5.1.36 && \
    rm -f ${JIRA_INSTALL_DIR}atlassian-jira/WEB-INF/lib/{activation,mail}-*.jar


USER ${RUN_USER}:${RUN_GROUP}

VOLUME ["${JIRA_INSTALL_DIR}"]

# HTTP Port
EXPOSE 8080

WORKDIR $JIRA_INSTALL_DIR

# Run in foreground
CMD ["./bin/start-jira.sh", "-fg"]