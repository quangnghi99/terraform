#----------------------------------------------------
# Transit Gateway
## Default association and propagation are disabled since our scenario involves
## a more elaborated setup where
## - Dev VPCs can reach themselves and the Shared VPC
## - the Shared VPC can reach all VPCs
## - the Prod VPC can only reach the Shared VPC
## The default setup being a full mesh scenario where all VPCs can see every other
resource "aws_ec2_transit_gateway" "tgw" {
  description = "3-vpc-tgw"
  # default_route_table_association = "disable"
  # default_route_table_propagation = "disable"

  tags = {
    Name = "3_VPC_Transit_Gateway"
  }
}

#----------------------------------------------------
## VPC attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-vpc-1" {
  subnet_ids         = [aws_subnet.vpc_1_private_subnet.id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.vpc_1.id
  #  transit_gateway_default_route_table_association = false
  #  transit_gateway_default_route_table_propagation = false

  tags               = {
    Name             = "tgw_att_vpc_1"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-vpc-2" {
  subnet_ids         = [aws_subnet.vpc_2_private_subnet.id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.vpc_2.id
  # transit_gateway_default_route_table_association = false
  # transit_gateway_default_route_table_propagation = false

  tags               = {
    Name             = "tgw_att_vpc_2"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-vpc-3" {
  subnet_ids         = [aws_subnet.vpc_3_private_subnet.id,aws_subnet.vpc_3_public_subnet.id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.vpc_3.id
  # transit_gateway_default_route_table_association = false
  # transit_gateway_default_route_table_propagation = false
  
  tags               = {
    Name             = "tgw_att_vpc_3"
  }
}

#----------------------------------------------------
## TGW Route Table
resource "aws_ec2_transit_gateway_route_table" "association_default_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}

# TGW Route Table
resource "aws_ec2_transit_gateway_route" "tgw_default_route" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-2.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.tgw.association_default_route_table_id
}
# # Inbound
# resource "aws_ec2_transit_gateway_route_table" "tgw-inbound-rt" {
#   transit_gateway_id = aws_ec2_transit_gateway.tgw.id

#   tags               = {
#     Name             = "tgw-inbound-rt"
#   }
# }
# resource "aws_ec2_transit_gateway_route" "tgw_rt" {
#   destination_cidr_block = "10.1.0.0/16"
#   transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-2.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-inbound-rt.id
# }
# resource "aws_ec2_transit_gateway_route" "tgw_rt" {
#   destination_cidr_block = "10.2.0.0/16"
#   transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-3.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-inbound-rt.id
# }

# # Outbound
# resource "aws_ec2_transit_gateway_route_table" "tgw-outbound-rt" {
#   transit_gateway_id = aws_ec2_transit_gateway.tgw.id

#   tags               = {
#     Name             = "tgw-outbound-rt"
#   }
# }
# resource "aws_ec2_transit_gateway_route" "outbound_inbound_tgw_route" {
#   destination_cidr_block = "10.0.0.0/16"
#   transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-1.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-outbound-rt.id
# }

# resource "aws_ec2_transit_gateway_route" "outbound_web_route" {
#   destination_cidr_block = "10.2.0.0/16"
#   transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-3.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-outbound-rt.id
# }

# # Web
# resource "aws_ec2_transit_gateway_route_table" "tgw-web-rt" {
#   transit_gateway_id = aws_ec2_transit_gateway.tgw.id

#   tags               = {
#     Name             = "tgw-web-rt"
#   }
# }

# resource "aws_ec2_transit_gateway_route" "web_inbound_route" {
#   destination_cidr_block = "0.0.0.0/0"
#   transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-1.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-web-rt.id
# }
# resource "aws_ec2_transit_gateway_route" "web_outbound_route" {
#   destination_cidr_block = "0.0.0.0/0"
#   transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-2.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-web-rt.id
# }
# resource "aws_ec2_transit_gateway_route" "web_blackhole_1" {
#   destination_cidr_block         = "10.0.0.0/8"
#   blackhole                      = true
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-web-rt.id
# }
# resource "aws_ec2_transit_gateway_route" "web_blackhole_2" {
#   destination_cidr_block         = "10.1.0.0/16"
#   blackhole                      = true
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-web-rt.id
# }

# # #----------------------------------------------------
# # # Route Tables Associations
# resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-vpc-1-assoc" {
#   transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-1.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-inbound-rt.id
# }

# resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-vpc-2-assoc" {
#   transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-2.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-outbound-rt.id
# }

# resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-vpc-3-assoc" {
#   transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-3.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-web-rt.id
# }

# #----------------------------------------------------
# # Route Tables Propagations
# ## This section defines which VPCs will be routed from each Route Table created 
# ## in the Transit Gateway
# resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-vpc-1-propa" {
#   transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-1.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-inbound-rt.id
# }

# resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-vpc-2-propa" {
#   transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-2.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-outbound-rt.id
# }

# resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-vpc-3-propa" {
#   transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-3.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-web-rt.id
# }