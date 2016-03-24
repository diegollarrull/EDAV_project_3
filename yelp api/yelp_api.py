###
#Consumer Key	R5P_xyFZ-bwmmv8wf8opCQ
#Consumer Secret	YIDTvnHGL7ca0t9GlxEgCYtnQbo
#Token	gMilIig9VdyrSVnrqZBoTkFnARB4WQol
#Token Secret	AlieRCAbn28ppTXt_dteyDHdRDk
###

from yelpapi import YelpAPI
import argparse
from pprint import pprint
from pymongo import MongoClient
import json
import csv
import time

client = MongoClient('localhost', 27017)
db = client.yelp_maryland
yelp_results_collection = db.yelp_results
argparser = argparse.ArgumentParser(description='Example Yelp queries using yelpapi. Visit https://www.yelp.com/developers/manage_api_keys to get the necessary API keys.')
argparser.add_argument('--consumer_key', type=str, help='Yelp v2.0 API consumer key')
argparser.add_argument('--consumer_secret', type=str, help='Yelp v2.0 API consumer secret')
argparser.add_argument('--token', type=str, help='Yelp v2.0 API token')
argparser.add_argument('--token_secret', type=str, help='Yelp v2.0 API token secret')
args = argparser.parse_args()
args.consumer_key = "R5P_xyFZ-bwmmv8wf8opCQ"
args.consumer_secret = "YIDTvnHGL7ca0t9GlxEgCYtnQbo"
args.token = "gMilIig9VdyrSVnrqZBoTkFnARB4WQol"
args.token_secret = "AlieRCAbn28ppTXt_dteyDHdRDk"
yelp_api = YelpAPI(args.consumer_key, args.consumer_secret, args.token, args.token_secret)


#attrs=BusinessParking.garage,BusinessParking.lot,BusinessParking.validated
#sortby=review_count

yelp_results_collection.remove()
#response = yelp_api.search_query(term='alcohol', location='Montgomery County, MD', sort=2, limit=20, offset=0)
#response2 = yelp_api.search_query(term='alcohol', location='Montgomery County, MD', sort=2, limit=20, offset=20)
#response_code = yelp_results_collection.insert(response)
#response_code2 = yelp_results_collection.insert(response2)

BaseLat = 38.9
BaseLon = -77.4

lat_intervals = [float(i) / 10 for i in xrange(5)]
lon_intervals = [float(i) / 10 for i in xrange(7)]

for lat in lat_intervals:
    for lon in lon_intervals:
        cll = str(BaseLat + lat) + ',' + str(BaseLon + lon)
        print cll
        response = yelp_api.search_query(term='alcohol', location='Montgomery County, MD', cll=cll, sort=1, limit=20, offset=0)
        response_code = yelp_results_collection.insert(response)
        time.sleep(10)


Lats2 = yelp_results_collection.aggregate([{'$project':{'coords': '$businesses.location.coordinate'}}])

f = open('./yelp.csv', 'w')
csv_file = csv.writer(f)
writer = csv.DictWriter(f, fieldnames = ['latitude','longitude'])
writer.writeheader()
for x in Lats2:
    for i in x['coords']:
        writer.writerow(i)




All = yelp_results_collection.find()
index = 0
for i in All:
    print i