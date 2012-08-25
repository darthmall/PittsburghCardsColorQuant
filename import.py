#! /usr/bin/env python

from argparse import ArgumentParser
import csv, couchdb

parser = ArgumentParser('Import a CSV file of greeting card color data to CouchDB')
parser.add_argument('datafile', metavar='CSV')
parser.add_argument('db', metavar='DB')

args = parser.parse_args()

couch = couchdb.Server('http://esheehan:bogus123@localhost:5984')

if args.db not in couch:
    couch.create(args.db)

db = couch[args.db]

with file(args.datafile, 'r') as f:
    reader = csv.reader(f)

    for line in reader:
        colors = []

        for i in range(1, len(line[1:]), 2):
            colors.append({
                'color': line[i],
                'frequency': float(line[i + 1])
                })


        doc = {
            '_id': line[0],
            'colors': colors,
            'date': '{}-{}'.format(line[0][:4], line[0][4:6]),
        }

        docId, docRev = db.save(doc)

        with file('data/img/{}.png'.format(docId), 'r') as attachment:
            db.put_attachment(db[docId], attachment, 'card.png')
