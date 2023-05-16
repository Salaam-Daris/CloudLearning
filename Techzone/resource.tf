
# resource "aws_instance" "myserver" {
#     ami= "ami-0cc939600fdaf7da8"
#     instance_type = "t2.micro"
    
#     tags = {
#     Name = "instance"
#   }
# }


# resource "aws_instance" "myserver" {
#   count = 2 

#   ami           = "ami-0cc939600fdaf7da8"
#   instance_type = "t2.micro"

#   tags = {
#     Name = "myinstance${count.index + 1}" 
#   }
# }