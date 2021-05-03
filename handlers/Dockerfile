FROM amazon/aws-lambda-nodejs:14

ARG handler
COPY ./package.json ./package-lock.json /var/task/
COPY ./common /var/task/common
COPY ./${handler} /var/task/handler

WORKDIR /var/task
RUN ["npm", "i", "--production"]

ENV LAMBDA_TASK_ROOT=/var/task/handler
CMD ["index.handler"]
