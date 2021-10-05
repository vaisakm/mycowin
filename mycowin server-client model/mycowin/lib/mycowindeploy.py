import requests
#import os
#import json
from datetime import datetime
import pytz
from dateutil import parser
#from tzlocal import get_localzone
from flask import Flask, jsonify

app = Flask(__name__)

timezone = pytz.timezone("Asia/Kolkata")  # instead of get_localzone()
# datetime type in local:datetime.datetime(2021, 5, 28, 22, 49, 20, tzinfo=<DstTzInfo 'Asia/Calcutta' IST+5:30:00 STD>)
last_updated = ""
# datetime type in local:datetime.datetime(2021, 5, 28, 22, 49, 20, tzinfo=<DstTzInfo 'Asia/Calcutta' IST+5:30:00 STD>)
last_fetched = ""
# string to save fail message instead of printing. Concat lines for multiple errors in same fn before save.
last_error = ""
headers = {
    'accept': 'application/json',
    'Accept-Language': 'en_US',
    'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36',
}
base_url = 'https://cdn-api.co-vin.in/api/v2/admin/location/'
states_url = 'https://cdn-api.co-vin.in/api/v2/admin/location/states'
centers_url = 'https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByDistrict'

availability_dict = {}


def fetchavailability(district_id):
    "get availability calendar from today for district"
    date = datetime.today().strftime('%d-%m-%Y')
    params = {'district_id': district_id, 'date': date}
    availability_request = requests.get(
        centers_url, params=params, headers=headers)
    global timezone
    global last_fetched
    last_fetched = parser.parse(datetime.now().strftime(
        "%a, %d %b %Y %H:%M:%S %Z")).astimezone(timezone)
    global last_updated
    last_updated = parser.parse(
        availability_request.headers['Date']).astimezone(timezone)

    global last_error
    if availability_request.status_code != 200:
        print("\nAvailability list not returned. ERROR %s" %
              (availability_request.status_code))
        last_error = str("Availability list not returned from CoWin. ERROR %s" % (
            availability_request.status_code))
        return False

    global availability_dict
    availability_dict = {}
    availability_dict = availability_request.json()
    return True


def check_availability(options):  
    "availability of centers with options filter applied"
    fetchreturn = fetchavailability(options['district_id'])
    global availability_dict
    global last_error
    global last_fetched
    global last_updated
    if fetchreturn == False:
        return jsonify({'status': False, 'error': last_error, 'notify': False, 'session_count': 0, 'last_fetched': last_updated.strftime("%a, %d %b %Y %H:%M:%S %Z"), 'last_updated': last_updated.strftime("%a, %d %b %Y %H:%M:%S %Z"), 'centers': []})
    mydict = {
        'status': True,
        'error': "Unknown",
        'notify': False,
        'session_count': 0,
        'centers': [],
        'last_fetched': last_fetched.strftime("%a, %d %b %Y %H:%M:%S %Z"),
        'last_updated': last_updated.strftime("%a, %d %b %Y %H:%M:%S %Z")
    }

    counter = 0
    for center in availability_dict['centers']:
        if (
            len(options['centers']) != 0
            and center['name'] not in options['centers']
        ):
            continue
        if (
            options['fee_type'] != "Any"
            and center['fee_type'] != options['fee_type']
        ):
            continue
        d = []
        for session in center['sessions']:
            if session['min_age_limit'] > options['min_age_limit']:
                continue
            if options['dose'] == 'Any' and session['available_capacity'] <= 0:
                continue
            if options['dose'] != 'Any' and (
                options['dose'] not in [1, 2]
                or options['dose'] == 1
                and session['available_capacity_dose1'] <= 0
                or options['dose'] == 2
                and session['available_capacity_dose2'] <= 0
            ):
                continue
            if session['vaccine'] != options['vaccine']:
                continue
            counter += 1
            session['center'] = center['name']
            d.append(session)
        if d:
            mydict['centers'].extend(d)
    if len(mydict['centers']) == 0:
        mydict['error'] = "No Results for set criteria"
        return jsonify(mydict)
    mydict['error'] = "None"
    mydict['notify'] = True
    mydict['session_count'] = counter
    return jsonify(mydict)


options = {
    'district_id': 298,
    'centers': ["Elamadu PHC",
                "Pooyapallly FHC",
                "Velinelloor CHC",
                "Veliyam FHC",
                "Adichanalloor PHC",
                "Chathannoor FHC",
                "Ezhukone Pavithreswaram FHC",
                "ESI Ezhukone",
                "Neduvathur PHC",
                "Thalachira PHC",
                "Chirakkara PHC",
                "Mylom PHC",
                "Mayyanad CHC",
                "Ummannoor FHC",
                "Melila FHC",
                "Thalachira PHC"],
    'dose': 1,
    'vaccine': "COVISHIELD",
    'fee_type': "Free",
    'min_age_limit': 25
}


@app.route('/mycowin', methods=["GET"])
def start_app():
    global timezone
    global availability_dict
    global last_error
    global last_fetched
    global last_updated
    global options
    return check_availability(options)


if __name__ == '__main__':
    app.run(debug=False)
