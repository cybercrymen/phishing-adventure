# Rex Hunts Phishing Adventure

This script will run on pretty much all linux machines.
Install instructions are below. Just clone it, chmod it and run it.
You will be promted for your bait/keyword and the script will do the rest.

## How It Works

Once you run the script you will then download a list of newly registered domains from the past 7 days. The script will then run though a filtering process to serve you domains with your keyword. Once the list has been compiled the script will then start submitting all the URLs to URLScan.io and output a results file for reference.

## Install

```
git clone https://github.com/cybercrymen/phishing-adventure.git

cd phishing-adventure

chmod u+x start.sh

./start.sh
```

At the end you'll be left with txt file names after the keyword you used...
