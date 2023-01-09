ARG PYTHON_VERSION
FROM python:${PYTHON_VERSION}-slim-bullseye as build
RUN apt update && apt install -y curl unzip wget

# Install aws-cli Manually
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip" && \
  unzip awscliv2.zip && \
  ./aws/install

# Install Terraform Manually
ARG TERRAFORM_VERSION
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_arm.zip && \
  unzip terraform_${TERRAFORM_VERSION}_linux_arm.zip

#######

FROM debian:bullseye-slim as dev
RUN apt update && apt install -y git
COPY --from=build /usr/local/aws-cli /usr/local/aws-cli
COPY --from=build /usr/local/bin /usr/local/bin
COPY --from=build ./terraform /usr/bin/terraform

# Install the "auto-complete" Terraform Extension
RUN terraform -install-autocomplete
