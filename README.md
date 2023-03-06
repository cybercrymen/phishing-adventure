# Rex Hunts Phishing Adventure

This script will run on pretty much all linux machines.
Install instructions are below. Just clone it, chmod it and run it.
You will be promted for your bait/keyword and the script will do the rest.

## How It Works

Once you run the script you will then download a list of newly registered domains from the past 7 days. The script will then run though a filtering process to serve you domains with your keyword. Once the list has been compiled the script will then start submitting all the URLs to URLScan.io and output a results file for reference.

## Install

Here is some instructions for Debain based systems like Ubuntu.

`sudo apt install git curl`

Now get the files.

`git clone https://github.com/cybercrymen/phishing-adventure.git; cd phishing-adventure; chmod u+x start.sh`

Before you run the script you need to add your URLSCAN API key to the file called urlscan.api as plain text.

You also need to replace my tag with your own inside tag.txt

`./start.sh`

At the end you'll be left with a txt file named after the keyword you used and a file called urlscan-results.txt for analysis.
Good luck and happy huntng!

### Add Me

Twitter [@CyberCrymen](https://twitter.com/cybercrymen)

### How To Report Phishing Domains

Check out my post on [Pastebin](https://pastebin.com/7k70VFdT) for lots of reporting forms.

#### Comment

Version 1.1 is now complete and is the bare bones of what can come.
- - -
I already have some ideas to do the following with URLScan
1. Search if url exists, disgard if it does
2. Scan urls (nothing changes here)
3. Filter domains from results that returned 400 into new list
