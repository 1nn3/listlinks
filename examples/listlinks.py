#!/usr/bin/env python3
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait
from urllib.parse import urljoin
import argparse, re, sys, time, traceback, os
parser = argparse.ArgumentParser(description='List all hyperlinks of an URI.')
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
	'--frame-recursion-max-depth',
	action="store",
	nargs='?',
	const=1,
	default=10,
	type=int,
	choices=None,
	required=False,
	help='The frame_recursion_max_depth value.',
	metavar=None,
	dest='frame_recursion_max_depth',
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
def list_links():
	for i in browser.find_elements_by_xpath("//a"):
		href = i.get_attribute("href") or ""
		href = urljoin(args.uri, href) or href
		text = i.text or ""
		text = re.sub("\s+", " ", text)
		sys.stdout.write ("%s\t%s" % (href, text))
		sys.stdout.write(os.linesep)
def get_frames (parrents=[]):
	frames = [];
	#for i in range(len(browser.find_elements_by_xpath("//iframe"))):
	#	frames.append(parrents + [i]) # frame position
	for i in browser.find_elements_by_xpath("//iframe"):
		frames.append(parrents + [i]) # frame element
	return frames
def walk_through_frames (frames):
	for i in frames:
		#sys.stderr.write("I: Switching to frame: %s\n" % i)
		if len(i) > args.frame_recursion_max_depth:
			sys.stderr.write("W: frame_recursion_max_depth reached!\n")
			continue
		browser.switch_to.frame(None) # main frame
		for j in i:
			browser.switch_to.frame(j)
		list_links()
		walk_through_frames(get_frames(i)) # sub frames
try:
	browser.get(args.uri)
	time.sleep(args.stay)
	list_links()
	walk_through_frames(get_frames([]))
	exit_code=0
except:
	traceback.print_exc()
	exit_code=1
finally:
	browser.quit()
	exit(exit_code)

