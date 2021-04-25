FROM amazon/aws-lambda-nodejs:14
COPY index.js package.json package-lock.json ./
RUN ["npm", "i", "--production"]
CMD ["index.handler"]
