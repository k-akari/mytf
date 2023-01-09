FROM debian:bullseye-slim as base

#######

FROM base as build
RUN apt update && apt install -y wget unzip

# Install Terraform Manually
ARG TERRAFORM_VERSION
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_arm.zip && \
  unzip terraform_${TERRAFORM_VERSION}_linux_arm.zip

#######

FROM base as dev
RUN apt update && apt install -y git
COPY --from=build ./terraform /usr/bin/terraform

# Install the "auto-complete" Terraform Extension
RUN terraform -install-autocomplete
