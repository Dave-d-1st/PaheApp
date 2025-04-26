import re
from bs4 import BeautifulSoup
import cloudscraper
import m3u8
requests = cloudscraper.create_scraper(
    browser={
        "browser":"chrome",
        "platform":"windows"
    }
)
url = "https://www.wcofun.net/adventure-time-season-3-episode-1-conquest-of-cuteness-morituri-te-salutamus"
headers ={'User-Agent': 'Dart/3.7 (dart:io)'}

r=requests.get(url,headers=headers)
print(r)
soup = BeautifulSoup(r.content,'lxml')
iframe = soup.find("iframe",id="anime-js-1")['src']
r=requests.get(iframe,headers=headers)
soup = BeautifulSoup(r.content,'lxml')
# pattern=re.compile(r'getRedirectedUrl\(\"(.+)\"')
# search=pattern.search(soup.text)
# final=search.group(1)
m3u8_link = BeautifulSoup(soup.find("video").contents[1],'lxml').find('source')['src']
r=requests.head(m3u8_link,headers=headers)
print(m3u8_link)  
m3u8_link = r.headers['Location']
headers = {
  # "host": "s01.cizgifilmlerizle.com",  
  # "origin": "https://vhs.watchanimesub.net",
  # "pragma": "no-cache",
  # "referer": "https://vhs.watchanimesub.net/",
  # "sec-ch-ua": "\"Microsoft Edge\";v=\"135\", \"Not-A.Brand\";v=\"8\", \"Chromium\";v=\"135\"",
  # "sec-ch-ua-mobile": "?0",
  # "sec-ch-ua-platform": "\"Windows\"",
  # "sec-fetch-dest": "empty",
  # "sec-fetch-mode": "cors",
  # "sec-fetch-site": "cross-site",
  "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0"
}

# r=requests.get('https://s01.cizgifilmlerizle.com/getvid/ksjMffctRZ-KsOgKVMcxhlkZC3BbB8pEiZJBkTjp_goTJb2_vdXrn4hyHkV-fhibXD7Q-COyl9Krm_oW_ItwZeerjA_zkmQcTvQXqVTrSBgcmAut85eZJive9OeKw2bOvKkQsbjmihDhCNDvmbkLW8Yn5Wbp3-NCgerWXg1mnIQKYOjLD2zKimxSqyqQac13keDb3VIBDNyYm_EaPdbG7gUPOL7jTbKyKhA88EBe1cId1BHEBVImkX7icft0oLqYsIbe_4knfcd2zojYh8_JCii-z31YVZVarPZUieCRnnuvc5ug9h3FhUmy9Tu8RGnK-9Mey0_kBkWKRzwRQcn7sruQCq_LwnzMDz6UO0OM4cjP1Ww2NmTcKPh9Sulj8_GoafPS4mI9H7i5UADVyhsCbw/0/854/index.m3u8',headers=headers)
# print(r.status_code)
# m3 = m3u8.load('https://s01.cizgifilmlerizle.com/getvid/ksjMffctRZ-KsOgKVMcxhlkZC3BbB8pEiZJBkTjp_goTJb2_vdXrn4hyHkV-fhibXD7Q-COyl9Krm_oW_ItwZeerjA_zkmQcTvQXqVTrSBgcmAut85eZJive9OeKw2bOvKkQsbjmihDhCNDvmbkLW8Yn5Wbp3-NCgerWXg1mnIQKYOjLD2zKimxSqyqQac13keDb3VIBDNyYm_EaPdbG7gUPOL7jTbKyKhA88EBe1cId1BHEBVImkX7icft0oLqYaEeB5ImfLT3cAdNMvQGOAGdOvfbEyYs19jnFyevi-W_ffqYO-46PrOKUB8nswFMnCSTTwtNvnl5DGB3yiEUlNASnP2yp3uRv1QDnG2FtGooeWDp0UCdJ6eCek6qCjLEe6bQx9VxwAHiGWsV0ShM2pQ/0/854/index.m3u8',headers=headers)
# print(m3.)
# with open(r"C:\Users\davem\Documents\Code\Flutter\m\mir.mp4",'ab') as f:
#   for sergment in m3.segments:
#     print(f"Downloading {sergment.uri}")
#     if "9" in sergment.uri:
#        break
#     r=requests.get(sergment.absolute_uri,headers=headers)    

#     if r.status_code<300:
#           f.write(r.content)
#     else:
#       print("Broken")
#       break
# print(m3.segments)
# print(r)
# print(r.text)
# print(r.headers)

# import requests

# url = "https://t02.cizgifilmlerizle.com//getvid?evid=HK123YvoXZpYaqvBMG6_Et7tsQZeflEv4HH4Yx9SvN2OhA7Ca7kRHu7La00Z3vHREPU0qVcU1Y2E2L1tx6uO4Q7oqtolZH2ZqCEylnc4bbmygMEr1CID8R5XsdHusf1aaYE97Bx7ry6t1AO2_veG0JNr79HKlLkLUcko_pgc2UAfTM-DluW2Hh4Zi4Ug6UYR8ljWA9Je1p7bwMzoPZXnNOIc3cCgoXq_hj9pfcv0auNFaU5VHAYe9mNMmkZEPNkPMAlNYnRZ1K_o3AB6W1mpMKAY7jxt08dbONJAyF8anrkqiCodT1es084wAgD9PyZT-xP-iOkNHvu_ddsOSV_VeqseAsVyr76XpHtfXrBg8r_so7weQsfxH2AbalYrCnRxe7eSz7suEiRkw47VP4i-P0fOFmEYMEVShcghTB4gp4TPoXbqCGzlL09_EXEu1Uye838tR5W-0MX8BsDB5W-1xZVQ6BHwRhhQkG91m5HRvzM&json"
# r=requests.get(url,headers=headers,stream=True)
# print(r)