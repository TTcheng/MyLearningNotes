#����
java -jar jenkins-cli.jar -s http://10.189.2.108:8888/ -auth admin:admin123 get-job jbsh-report-server > jbsh-report-server.xml
#����
java -jar jenkins-cli.jar -s http://10.189.2.108:8888/ -auth admin:admin123 get-job jbsh-report-server < jbsh-report-server.xml
