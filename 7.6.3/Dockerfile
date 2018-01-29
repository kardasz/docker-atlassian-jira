FROM debian:stretch

# Update system and install required packages
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qq \
    && apt-get install -y wget curl git unzip libtcnative-1 xmlstarlet gosu \
    && apt-get clean autoclean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

# Oracle JDK
ENV ORACLE_JDK_VERSION jdk-8u161
ENV ORACLE_JDK_URL http://download.oracle.com/otn-pub/java/jdk/8u161-b12/2f38c3b165be4555a1fa6e98c45e0808/jdk-8u161-linux-x64.tar.gz
RUN mkdir -p /opt/jdk/$ORACLE_JDK_VERSION && \
    wget --header "Cookie: oraclelicense=accept-securebackup-cookie" -O /opt/jdk/$ORACLE_JDK_VERSION/$ORACLE_JDK_VERSION.tar.gz $ORACLE_JDK_URL && \
    tar -zxf /opt/jdk/$ORACLE_JDK_VERSION/$ORACLE_JDK_VERSION.tar.gz --strip-components=1 -C /opt/jdk/$ORACLE_JDK_VERSION && \
    rm /opt/jdk/$ORACLE_JDK_VERSION/$ORACLE_JDK_VERSION.tar.gz && \
    update-alternatives --install /usr/bin/java java /opt/jdk/$ORACLE_JDK_VERSION/bin/java 100 && \
    update-alternatives --install /usr/bin/javac javac /opt/jdk/$ORACLE_JDK_VERSION/bin/javac 100

ENV DOWNLOAD_URL        https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-

ENV JAVA_HOME /opt/jdk/${ORACLE_JDK_VERSION}

ENV JAVA_TRUSTSTORE ${JAVA_HOME}/jre/lib/security/cacerts
ENV JAVA_TRUSTSTORE_PASSWORD changeit
ENV JAVA_OPTS "-Djavax.net.ssl.trustStore=${JAVA_TRUSTSTORE} -Djavax.net.ssl.trustStorePassword=${JAVA_TRUSTSTORE_PASSWORD}"

ENV RUN_USER            atlassian
ENV RUN_USER_UID        5000
ENV RUN_GROUP           atlassian
ENV RUN_GROUP_GID       5000

RUN \
    groupadd --gid ${RUN_GROUP_GID} -r ${RUN_GROUP} && \
    useradd -r --uid ${RUN_USER_UID} -g ${RUN_GROUP} ${RUN_USER}

ENV JIRA_VERSION 7.6.3
ENV JIRA_HOME /var/atlassian/jira/data
ENV JIRA_INSTALL_DIR /opt/atlassian/jira

RUN mkdir -p ${JIRA_INSTALL_DIR} ${JIRA_HOME} && \
    curl -L --silent  ${DOWNLOAD_URL}${JIRA_VERSION}.tar.gz | tar -xz --strip=1 -C "$JIRA_INSTALL_DIR" && \
    chown -R ${RUN_USER}:${RUN_GROUP} ${JIRA_HOME} ${JIRA_INSTALL_DIR}

# MySQL connector
ENV MYSQL_CONNECTOR_VERSION 5.1.44
RUN \
    wget -O ${JIRA_INSTALL_DIR}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.tar.gz http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.tar.gz && \
    tar xzf ${JIRA_INSTALL_DIR}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.tar.gz -C ${JIRA_INSTALL_DIR} && \
    mv ${JIRA_INSTALL_DIR}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}-bin.jar ${JIRA_INSTALL_DIR}/lib/ && \
    rm -rf ${JIRA_INSTALL_DIR}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.tar.gz ${JIRA_INSTALL_DIR}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}

ENV PATH $JIRA_INSTALL_DIR/bin:$JAVA_HOME/bin:$PATH

EXPOSE 8080

COPY docker-entrypoint.sh /entrypoint.sh

RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

WORKDIR $JIRA_INSTALL_DIR

CMD ["start-jira.sh", "-fg"]
