resource "aws_vpc" "vpc" {
	cidr_block = "25.1.0.0/16"
	enable_dns_hostnames = true
	enable_dns_support = true
	assign_generated_ipv6_cidr_block = true
	tags = merge({
		Name = "${var.prefix}-${var.name}"
	}, local.commonTags)	
}

resource "aws_internet_gateway" "igw" {
	vpc_id = aws_vpc.vpc.id
	tags = merge({
		Name = "${var.prefix}-igw"
	}, local.commonTags)	
}

resource "aws_egress_only_internet_gateway" "eigw" {
    vpc_id = aws_vpc.vpc.id
    tags = merge({
        Name = "${var.prefix}-eigw"
    }, local.commonTags)
}

resource "aws_subnet" "public_1" {
	vpc_id = aws_vpc.vpc.id
	cidr_block = "25.1.0.0/24"
	availability_zone = "${var.region}a"
	map_public_ip_on_launch = true
	tags = merge({
		Name = "${var.prefix}-public-1a"
	}, local.commonTags)
}

resource "aws_subnet" "public_2" {
	vpc_id = aws_vpc.vpc.id
	cidr_block = "25.1.2.0/24"
	availability_zone = "${var.region}b"
	map_public_ip_on_launch = true
	tags = merge({
		Name = "${var.prefix}-public-1b"
	}, local.commonTags)
}

resource "aws_eip" "nat_eip" {
	tags = merge({
		Name = "${var.prefix}-eip"
	}, local.commonTags)
}

resource "aws_nat_gateway" "natgw" {
	allocation_id = aws_eip.nat_eip.id
	subnet_id = aws_subnet.public_1.id
	tags = merge({
		Name = "${var.prefix}-nat"
	}, local.commonTags)
}

resource "aws_subnet" "private_1" {
	vpc_id = aws_vpc.vpc.id
	cidr_block = "25.1.1.0/24"
	availability_zone = "${var.region}a"
	map_public_ip_on_launch = false
	tags = merge({
		Name = "${var.prefix}-private-1a"
	}, local.commonTags)
}

resource "aws_subnet" "private_2" {
	vpc_id = aws_vpc.vpc.id
	cidr_block = "25.1.3.0/24"
	availability_zone = "${var.region}b"
	map_public_ip_on_launch = false
	tags = merge({
		Name = "${var.prefix}-private-1b"
	}, local.commonTags)
}

resource "aws_route_table" "public" {
	vpc_id = aws_vpc.vpc.id

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.igw.id
	}

	route {
		ipv6_cidr_block = "::/0"
		gateway_id = aws_egress_only_internet_gateway.eigw.id	
	}

	tags = merge({
		Name = "${var.prefix}-rtb-public"
	}, local.commonTags)
}

resource "aws_route_table" "private" {
	vpc_id = aws_vpc.vpc.id

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_nat_gateway.natgw.id
	}

	route {
		ipv6_cidr_block = "::/0"
		gateway_id = aws_egress_only_internet_gateway.eigw.id
	}

	tags = merge({
		Name = "${var.prefix}-rtb-private"
	}, local.commonTags)
}

resource "aws_route_table_association" "public_1" {
	subnet_id = aws_subnet.public_1.id
	route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
	subnet_id = aws_subnet.public_2.id
	route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_1" {
	subnet_id = aws_subnet.private_1.id
	route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
	subnet_id = aws_subnet.private_2.id
	route_table_id = aws_route_table.private.id
}

