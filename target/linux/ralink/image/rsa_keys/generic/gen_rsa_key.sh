#!/bin/sh
openssl genrsa -out rsa_private.key 2048
openssl rsa -in rsa_private.key -pubout -out rsa_public.key
