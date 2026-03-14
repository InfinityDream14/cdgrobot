import requests
import random
import json
import string

class CommonLibrary():
    
    def get_users(self):
        response = requests.get('https://jsonplaceholder.typicode.com/users/', verify=False)
        users = response.json()
        for user in users:
            name_list = self.remove_shortest_string(user['name'])
            user['first_name'] = name_list[0]
            user['last_name'] = name_list[1]
            user.pop('name')
            user['birthday'] = self.get_random_birthday()
            user['password'] = self.generate_password()
            addr = user["address"]
            user["address"]["stateAbbr"] = (addr["street"][0] + addr["suite"][0] + addr["city"][0]).upper()
            user['zipcode'] = addr['zipcode']
        return users

    def remove_shortest_string(self, name):
        string_list = name.split(' ')
        if len(string_list) > 2:
            string_list.remove(min(string_list, key=len))
        return string_list

    def get_random_birthday(self):
        day = str(random.randint(1,28)).zfill(2)
        month = str(random.randint(1,12)).zfill(2)
        year = str(random.randint(1999,2006))

        return f"{month}/{day}/{year}"
    
    def generate_password(self, length=8):
        chars = string.ascii_letters + string.digits + "!@#$%"
        return ''.join(random.choice(chars) for _ in range(length))