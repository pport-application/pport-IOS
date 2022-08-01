#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Jan 27 16:39:44 2022

@author: akmami
"""

import smtplib, ssl

port = 465  # For SSL
smtp_server = "smtp.gmail.com"
sender_email = "pport.application@gmail.com"  # Enter your address
receiver_email = "akmuhammet99@gmail.com"  # Enter receiver address
password = "zpgmrtlimodxgvmi"
message = """\
Subject: Hi there

This message is sent from Python."""

context = ssl.create_default_context()
with smtplib.SMTP_SSL(smtp_server, port, context=context) as server:
    server.login(sender_email, password)
    server.sendmail(sender_email, receiver_email, message)