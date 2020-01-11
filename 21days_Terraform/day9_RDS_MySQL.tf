resource "aws_db_instance" "my-test-sql" {
  instance_class = "${var.db_instance}"
  engine = "mysql"
  engine_version = "5.7"
  multi_az = true
  storage_type = "gp2"
  allocated_storage = 20
  name = "mytestrds"
  username = "admin"
  password = "admin#1717"
  apply_immediately = true
  db_subnet_group_name = "${aws_db_subnet_group.my-rds-db-subnet.name}"
}
resource "aws_db_subnet_group" "my-rds-db-subnet" {
  name = "my-rds-subnet"
  subnet_ids = ["${var.rds_subnet1}","${var.rds_subnet2}"]
}
resource "aws_security_group" "my-rds-sg" {
  name = "my-rds-sg"
  vpc_id = "${var.vpc_id}"
}
resource "aws_security_group_rule" "my-rds-sg-rule" {
  from_port = 3306
  protocol = "tcp"
  security_group_id = "${aws_security_group.my-rds-sg.id}"
  to_port = 3306
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "outbound_rul" {
  from_port = 0
  protocol = "-1"
  security_group_id = "${aws_security_group.my-rds-sg.id}"
  to_port = 0
  type = "egress"
  cidr_blocks = ["0.0.0.0/0"]
}

/*

* allocated_storage: This is the amount in GB
* storage_type: Type of storage we want to allocate(options avilable "standard" (magnetic), "gp2" (general purpose SSD), or "io1" (provisioned IOPS SSD)
* engine: Database engine(for supported values check https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html) eg: Oracle, Amazon Aurora,Postgres
* engine_version: engine version to use
* instance_class: instance type for rds instance
* name: The name of the database to create when the DB instance is created.
* username: Username for the master DB user.
* password: Password for the master DB user
* db_subnet_group_name:  DB instance will be created in the VPC associated with the DB subnet group. If unspecified, will be created in the default VPC
* vpc_security_group_ids: List of VPC security groups to associate.
* allows_major_version_upgrade: Indicates that major version upgrades are allowed. Changing this parameter does not result in an outage
 and the change is asynchronously applied as soon as possible.
* auto_minor_version_upgrade:Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window. Defaults to true.
* backup_retention_period: The days to retain backups for. Must be between 0 and 35. When creating a Read Replica the value must be greater than 0
* backup_window:The daily time range (in UTC) during which automated backups are created if they are enabled. Must not overlap with maintenance_window
* maintainence_window:The window to perform maintenance in. Syntax: "ddd:hh24:mi-ddd:hh24:mi".
* multi_az: Specifies if the RDS instance is multi-AZ
* skip_final_snapshot: Determines whether a final DB snapshot is created before the DB instance is deleted. If true is specified,
no DBSnapshot is created. If false is specified, a DB snapshot is created before the DB instance is deleted, using the value from
final_snapshot_identifier. Default is false

*/