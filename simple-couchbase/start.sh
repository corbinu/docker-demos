#!/bin/bash

cd consul

./start.sh

cd ../couchbase

./start.sh

cd ../demo

./start.sh
