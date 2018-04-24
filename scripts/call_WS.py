import httplib
import sys

webservice = sys.argv[1]
soap_request_file = sys.argv[2]

url = webservice.split("/")

request = open(soap_request_file,"r").read()
webservice = httplib.HTTP("%s" % url[2])
webservice.putrequest("POST", "/%s" % url[3])
webservice.putheader("Host", "localhost")
webservice.putheader("User-Agent", "Python post")
webservice.putheader("Content-type", "text/xml; charset=\"UTF-8\"")
webservice.putheader("Content-length", "%d" % len(request))
webservice.endheaders()
webservice.send(request)
statuscode, statusmessage, header = webservice.getreply()
result = webservice.getfile().read()
print statuscode