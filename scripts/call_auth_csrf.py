from xml.etree import ElementTree
import requests
import sys

url = sys.argv[1]
user = sys.argv[2]
password = sys.argv[3]

session = requests.session()

# Call login page to get the Cookie containing the jsessionid and csrf hidden field
r = session.get(url)

# Parse html response to extract the csrf field
html = r.text.encode("iso-8859-1")
tree = ElementTree.fromstring(html)
csrf = tree.find(".//input[@type='hidden']")
csrf_value = csrf.attrib.get('value')
# print("CSRF returned : %s" % csrf_value)

# Issue login auth request
payload = {'username': user, 'password': password}
headers = {'X-CSRF-TOKEN': csrf_value, 'Referer': url}
r = session.post(url, data=payload, headers=headers)

# print("Response status : %s" % r.status_code)
print(r.text)

