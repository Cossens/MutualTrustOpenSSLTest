#!/bin/bash

echo CLEANING CERTS...
rm -fv certs/*
rm -fv crl/*
rm -fv csr/*
rm -fv private/*
rm -fv temp/*
echo
echo CLEANING CONFIG...
rm -fv config/*
echo
echo CLEANING DATABASES...
rm -fv db/*

