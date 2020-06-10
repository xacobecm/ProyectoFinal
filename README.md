# PROYECTO FINAL DAM

## Tecnologías empleadas

Aplicación en NodeJS y React conectada a una base de datos Mongo.

La aplicación ha sido Dockerizada y alojada en un repositorio de imágenes Docker privado. Se ha desplegado en un clúster de Kubernetes a través de un pipeline de despliegue continuo en Azure Pipelines. Esta infraestructura se compone de 2 máquinas virtuales y un clúster AKS, todo ello montado en el cloud de Azure, además de una Pipeline y un repo en Azure DevOps. Toda la infraestructura se ha desplegado con Terraform, una tecnología de infraestructura como código.