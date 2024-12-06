# Create subnet
resource "aws_subnet" "terraform-subnet" {
  vpc_id                  = aws_vpc.terraform-vpc.id
  cidr_block              = var.subnet_block
  map_public_ip_on_launch = true  # Ensures public IPs are assigned automatically

  tags = {
    Name = var.subnet_name
  }
}

# Create route table
resource "aws_route_table" "terrfaorm-routeTable" {
  vpc_id = aws_vpc.terraform-vpc.id

  # Route for IPv4 internet traffic
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  # Route for IPv6 internet traffic (if needed)
  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }

  tags = {
    Name = var.route-table-name
  }
}

# Associate subnet with the custom route table
resource "aws_route_table_association" "subnet_association" {
  subnet_id      = aws_subnet.terraform-subnet.id
  route_table_id = aws_route_table.terrfaorm-routeTable.id
}
