/*
A record is used to translate human-friendly domain names such as “www.example.com” into IP-addresses such as
192.168.0.1 (machine friendly numbers).

A Canonical Name record (abbreviated as CNAME record) is a type of resource record in the Domain Name System (DNS) which maps one
domain name (an alias) to another (the Canonical Name.)

NS-records identify the DNS servers responsible (authoritative) for a zone.
Amazon Route 53 automatically creates a name server (NS) record that has the same name as your hosted zone.
It lists the four name servers that are the authoritative name servers for your hosted zone. Do not add, change,
or delete name servers in this record.

A Start of Authority record (abbreviated as SOA record) is a type of resource record in the Domain Name System (DNS) containing
administrative information about the zone, especially regarding zone transfers.
*/

resource "aws_route53_zone" "my-test-zone" {
  name = "example.com"
  comment = "This is test zone"
  vpc {
    vpc_id = "${var.vpc_id}"
  }
}
resource "aws_route53_record" "my-example-record" {
  count = "${length(var.hostname)}"
  name = "${element(var.hostname,count.index )}"
  type = "A"
  zone_id = "${aws_route53_zone.my-test-zone.id}"
  ttl = "300"
  records = ["${element(var.arecord,count.index )}"]
}

/*
element retrieves a single element from a list.

element(list, index)"

The index is zero-based. This function produces an error if used with an empty list.

Use the built-in index syntax list[index] in most cases. Use this function only for the special additional "wrap-around" behavior
described below.

https://www.terraform.io/docs/configuration/functions/element.html

*/