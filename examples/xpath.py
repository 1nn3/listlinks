#!/usr/bin/env python3
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait
from urllib.parse import urljoin
import argparse, re, sys, time, traceback, os
parser = argparse.ArgumentParser(description='Get a XPath of an URI.')
parser.add_argument(
	'-u', '--uri',
	action="store",
	nargs='?',
	const=1,
	default="https://www.example.net",
	type=str,
	choices=None,
	required=True,
	help='URI list links from.',
	metavar=None,
	dest='uri',
)
parser.add_argument(
	'-x', '--xpath expression',
	action="store",
	nargs='?',
	const=1,
	default="*",
	type=str,
	choices=None,
	required=True,
	help='The XPath expression.',
	metavar=None,
	dest='xpath',
)
parser.add_argument(
	'-t, --timeout',
	action="store",
	nargs='?',
	const=1,
	default=10,
	type=int,
	choices=None,
	required=False,
	help='Timeout.',
	metavar=None,
	dest='timeout',
)
parser.add_argument(
	'--stay',
	action="store",
	nargs='?',
	const=1,
	default=0.0,
	type=float,
	choices=None,
	required=False,
	help='Stay on site for amount of time (seconds).',
	metavar=None,
	dest='stay',
)
args = parser.parse_args()
browser = webdriver.Chrome()
#browser.set_script_timeout(args.timeout)
#browser.implicitly_wait(args.timeout)
#browser.set_page_load_timeout(args.timeout)
try:
	browser.get(args.uri)
	time.sleep(args.stay)
	for i in browser.find_elements_by_xpath(args.xpath):
		sys.stdout.write (i.text or "")
		sys.stdout.write(os.linesep)
	exit_code=0
except:
	traceback.print_exc()
	exit_code=1
finally:
	browser.quit()
	exit(exit_code)

