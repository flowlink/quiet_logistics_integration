# Quiet Logistics Integration

This is a fully hosted and supported integration for use with the [FlowLink](http://flowlink.io/) product. With this integration you can perform the following functions:

* Send RMA's to Quiet Logistics
* Send item profiles to Quiet Logistics
* Send purchase orders to Quiet Logistics
* Send shipment orders to Quiet Logistics
* Retrieve shipping confirmations from Quiet Logistics
* Retrieve PO receipts from Quiet Logistics
* Retrieve RMA receipts from Quiet Logistics
* Retrieve inventory levels from Quiet Logistics
* Retrieve error messages associated with previous operations

## Troubleshooting
To quickly view what's in your QL buckets and queues:

```
export QL_ACCESS_KEY_ID=[your access key id]
export QL_SECRET_ACCESS_KEY=[your secret access key]
ruby scripts/sanity_check.rb
```

# About FlowLink

[FlowLink](http://flowlink.io/) allows you to connect to your own custom integrations.
Feel free to modify the source code and host your own version of the integration
or better yet, help to make the official integration better by submitting a pull request!

This integration is 100% open source an licensed under the terms of the New BSD License.

![FlowLink Logo](http://flowlink.io/wp-content/uploads/logo-1.png)
