# for setting up auth login inside app instead of server configuration
from flask_httpauth import HTTPBasicAuth
import requests
import os
from datetime import datetime
import pytz
from dateutil import parser
import json
#from tzlocal import get_localzone
from flask import Flask, jsonify, request

THIS_FOLDER = os.path.dirname(os.path.abspath(__file__))
#my_file = os.path.join(THIS_FOLDER, '/data/myfile.txt')

#from flask_login import login_required
auth = HTTPBasicAuth()


@auth.verify_password
def verify(username, password):
    return (
        username == 'userNAME'
        and password == 'pASS'
    )


app = Flask(__name__)

timezone = pytz.timezone("Asia/Kolkata")  # instead of get_localzone()
# last_updated="" #datetime type in local:datetime.datetime(2021, 5, 28, 22, 49, 20, tzinfo=<DstTzInfo 'Asia/Calcutta' IST+5:30:00 STD>)
# last_attempted="" #datetime type in local:datetime.datetime(2021, 5, 28, 22, 49, 20, tzinfo=<DstTzInfo 'Asia/Calcutta' IST+5:30:00 STD>)
# above variables are now served to app as string in readable format.
# message="" #string to save fail message instead of printing. Concat lines for multiple errors in same fn before sending.
# availability_dict={}

headers = {
    'accept': 'application/json',
    'Accept-Language': 'en_US',
    'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36',
}
#base_url= 'https://cdn-api.co-vin.in/api/v2/admin/location/'
# states_url='https://cdn-api.co-vin.in/api/v2/admin/location/states'
centers_url = 'https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByDistrict'


def fetch_availability(district_id):
    "get availability calendar from today for district"
    global timezone
    timenow = datetime.now()
    last_attempted = parser.parse(timenow.strftime(
        "%a, %d %b %Y %H:%M:%S %Z")).astimezone(timezone)

    date = timenow.strftime('%d-%m-%Y')
    params = {'district_id': district_id, 'date': date}
    try:
        availability_request = requests.get(
            centers_url, params=params, headers=headers)
    except:
        message = "Unable to connect. Network/server issue."
        last_updated = ""
        return False, message, {}, last_attempted, last_updated
    else:
        if availability_request.status_code != 200:
            last_updated = ""
            message = str("Bad response from server. Error %s." %
                          (availability_request.status_code))
            return False, message, {}, last_attempted, last_updated
        else:
            last_updated = parser.parse(
                availability_request.headers['Date']).astimezone(timezone)
            message = "Data fetched."
            availability_dict = availability_request.json()
            return True, message, availability_dict, last_attempted, last_updated


def check_availability(options, response, message, availability_dict, last_attempted, last_updated):
    "availability of centers with options filter applied. Can be called with params(options, + return of above fn)"
    #response, message, availability_dict, last_attempted, last_updated = fetch_availability(options['district_id'])
    mydict = {'status': False, 'message': message, 'notify': False, 'last_attempted': last_attempted,
              'last_updated': last_updated, 'session_count': 0, 'centers': [], 'centerlist': {}}

    if response == False:
        return jsonify(mydict)

    counter = 0
    for center in availability_dict['centers']:
        mydict['centerlist'][center['center_id']] = center['name']
        if (
            len(options['centers']) > 0
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
            if session[options['dose']] == 0:
                continue
            if (
                options['vaccine'][0] != 'Any'
                and session['vaccine'] not in options['vaccine']
            ):
                continue
            counter += 1
            d.append(session)
        if d:
            mydict['centers'].append(d)
    if len(mydict['centers']) == 0:
        mydict['status'] = True
        mydict['message'] = "No Results for set criteria"
    else:
        mydict['message'] = "While results served are almost^ realtime, bookings will cause results to change quickly. ^The data is cached and may be up to 5 minutes old."
        mydict['notify'] = True
        mydict['session_count'] = counter

    return jsonify(mydict)


@app.route('/fetch_process_sessions', methods=['GET', 'POST'])
@auth.login_required
def fetch_sessions():
    "fetch availability, filter and return formatted data"
    centers_choice = [
        center
        for center in [
            request.args.get('center1'),
            request.args.get('center2'),
            request.args.get('center3'),
        ]
        if center != 'None'
    ]

    options = {
        'district_id': request.args.get('district_id'),
        'centers': centers_choice,
        'dose': "available_capacity_dose1",
        'vaccine': request.args.get('vaccine'),
        'fee_type': request.args.get('fee_type'),
        'min_age_limit': request.args.get('min_age_limit')
    }
    return check_availability(options, *fetch_availability(options['district_id']))


# use post instead of get to......obfuscate id/passwords while sending requests.
@app.route('/process_sessions', methods=['GET', 'POST'])
@auth.login_required
def process_availabilty():
    "process, format and return availability data send by client"
    centers_choice = [
        center
        for center in [
            request.args.get('center1'),
            request.args.get('center2'),
            request.args.get('center3'),
        ]
        if center != 'None'
    ]

    options = {
        'district_id': request.args.get('district_id'),
        'centers': centers_choice,
        'dose': "available_capacity_dose1",
        'vaccine': request.args.get('vaccine'),
        'fee_type': request.args.get('fee_type'),
        'min_age_limit': request.args.get('min_age_limit')
    }
    return check_availability(options, True, request.args.get('message'), request.args.get('availability_dict'), request.args.get('last_attempted'), request.args.get('last_updated'))


if __name__ == '__main__':
    app.run(debug=False)
