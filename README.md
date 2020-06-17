# Alma-PRISM Invoice
A transform to take Alma invoices and create a PRISM flat file

## Background
Given an Alma XML export for invoices, as described by the [Invoice Payment schema](https://developers.exlibrisgroup.com/alma/apis/docs/xsd/invoice_payment.xsd/), transform the exported invoices into a flat file suitable for ingest into PRISM.  Trigger a run of the Integration Profile to export the Invoices at an arbitrary time.

## Requirements

### Transformation

* XSL 3.0

Stylesheet will expect to write output files by name to the current directory.

### cron script

* PHP 7.x
* composer for `tcdent/php-restclient`
* Alma API key configured in config.php

PHP script will call the Alma API to schedule a run of the Integration Profile

## Copyright and License
Copyright University of Pittsburgh; Licensed under GPL v3 or later.

