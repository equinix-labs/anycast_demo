# Metal Anycast

Building an Anycast application in 5 minutes on Equinix Metal using Terraform

[Also see my blog: Building a high available Anycast application in 5 minutes on Packet](https://medium.com/@atoonk/building-a-high-available-anycast-application-in-5-minutes-on-packet-198c82eaabc)

_Defining and deploying your applications like we did here, using infrastructure as code and Anycast used to be reserved for the large CDN’s, DNS and major infrastructure providers. Packet now makes it easy for everyone to build high available and low latency infrastructure. Working with Packet has been a great experience and I recommend everyone to give it a spin._

To try this your self:
just clone this repo, add a `something.tfvars` file with your packet API key.
then run:
```
terraform init
terraform plan
terraform apply
```
and you should be good to go.
