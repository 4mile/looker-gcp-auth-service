FROM node:16
WORKDIR /usr/src/app
COPY . ./
RUN yarn install
EXPOSE 8080
CMD ["node", "src/index.js"]