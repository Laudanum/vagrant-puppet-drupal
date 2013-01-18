#!/bin/bash


# http://www.gazoakley.com/content/installing-apache-solr-3.6-3.x-ubuntu-debian

# Download/Install Solr
wget http://mirror.lividpenguin.com/pub/apache/lucene/solr/3.6.0/apache-solr-3.6.0.tgz
sudo tar -C /usr/share/solr -zxf apache-solr-3.6.0.tgz 

wget http://svn.codehaus.org/jetty/jetty/branches/jetty-6.1/bin/jetty.sh
sudo cp jetty.sh /etc/init.d/jetty
sudo chmod 755 /etc/init.d/jetty

# Configure Jetty
cat > /etc/default/jetty << EOF
JAVA_HOME=/usr/java/default
JAVA_OPTIONS="-Dsolr.solr.home=/usr/share/solr/example/solr \$JAVA_OPTIONS"
JETTY_HOME=/usr/share/solr/example
JETTY_USER=solr
JETTY_LOGS=/var/log/solr
JAVA_HOME=/usr/lib/jvm/default-java
JDK_DIRS="/usr/lib/jvm/default-java /usr/lib/jvm/java-6-sun"
EOF

# Configure Jetty Logging
mkdir -p /var/log/solr
cat > /usr/share/solr/example/etc/jetty-logging.xml <<EOF
<?xml version="1.0"?>
<!DOCTYPE Configure PUBLIC "-//Mort Bay Consulting//DTD Configure//EN" "http://jetty.mortbay.org/configure.dtd">
<!-- =============================================================== -->
<!-- Configure stderr and stdout to a Jetty rollover log file -->
<!-- this configuration file should be used in combination with -->
<!-- other configuration files. e.g. -->
<!-- java -jar start.jar etc/jetty-logging.xml etc/jetty.xml -->
<!-- =============================================================== -->
<Configure id="Server" class="org.mortbay.jetty.Server">
<New id="ServerLog" class="java.io.PrintStream">
<Arg>
<New class="org.mortbay.util.RolloverFileOutputStream">
<Arg><SystemProperty name="jetty.logs" default="."/>/yyyy_mm_dd.stderrout.log</Arg>
<Arg type="boolean">false</Arg>
<Arg type="int">90</Arg>
<Arg><Call class="java.util.TimeZone" name="getTimeZone"><Arg>GMT</Arg></Call></Arg>
<Get id="ServerLogName" name="datedFilename"/>
</New>
</Arg>
</New>
<Call class="org.mortbay.log.Log" name="info"><Arg>Redirecting stderr/stdout to <Ref id="ServerLogName"/></Arg></Call>
<Call class="java.lang.System" name="setErr"><Arg><Ref id="ServerLog"/></Arg></Call>
<Call class="java.lang.System" name="setOut"><Arg><Ref id="ServerLog"/></Arg></Call>
</Configure>
EOF

# Create Solr user
useradd -d /usr/share/solr -s /bin/false solr
chown solr:solr -R /usr/share/solr
chown solr:solr -R /var/log/solr

# Run Jetty/Solr at startup
update-rc.d jetty defaults

# Starting Jetty/Solr
service jetty start

