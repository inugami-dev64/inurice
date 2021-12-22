#!/usr/bin/python3

import csv
import sys
import time
import subprocess

# Constant declarations
PROGRAM_TABLE_DATA = "programs.csv"
PROGRAM_TABLE_DECL = "#PROGRAMS"
INDEX_HTML_TEMPLATE = "templates/index.html"
INDEX_HTML = "index.html"
URL_DELIMITERS = ('(', ')')
GIT_PULL_UP_TO_DATE_MSG = "Already up to date.\n"
DAEMON_SLEEP_INTERVAL = 60


# Parse link data from given element and return a pair containing a name and url
def parse_links(item):
    beg = item.find(URL_DELIMITERS[0]);
    end = item.find(URL_DELIMITERS[1]);

    # Delimiter locations are correct
    if beg != -1 and end != -1 and beg < end:
        url = item[beg + 1:end]
        if url.find("https://") != -1:
            title = item[:beg]
            return (title, url)

    return ""


# Create html tables from programs.
def create_program_table_html():
    csvfile = open(PROGRAM_TABLE_DATA, newline='')
    contents = csv.reader(csvfile, delimiter=",", quotechar="\"")
    html = ""

    # Iterate through contents and create html data
    i = 0
    for row in contents:
        html += "<tr>\n"
        for item in row:
            beg = ""
            end = ""

            # Create table header
            if i == 0:
                beg = "<th>"
                end = "</th>\n"
            else:
                beg = "<td>"
                end = "</td>\n"
            url = parse_links(item)
            html += beg
            if type(url) == type(()):
                html += "<a href=\"" + url[1] + "\">" + url[0] + "</a>"
            else:
                html += item

            html += end
        html += "</tr>\n"
        i += 1

    return html


# Write an index.html file from template
def write_html(html):
    data = open(INDEX_HTML_TEMPLATE, 'r').read()
    data = data.replace(PROGRAM_TABLE_DECL, html)
    open(INDEX_HTML, 'w').write(data)


# Check if daemon was requested
if len(sys.argv) == 2 and sys.argv[1] == "--daemon":
    while True:
        pull = subprocess.check_output("git pull origin master", shell=True)

        if pull.decode("UTF-8") != GIT_PULL_UP_TO_DATE_MSG:
            html = create_program_table_html()
            write_html(html)

        time.sleep(DAEMON_SLEEP_INTERVAL)

else:
    html = create_program_table_html()
    write_html(html)
