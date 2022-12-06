FROM node:17-alpine
WORKDIR /usr/src/app
COPY . .
RUN npm install

# Build the client
RUN --mount=type=secret,id=REACT_APP_MY_API_URL \
export REACT_APP_MY_API_URL=$(cat /run/secrets/REACT_APP_MY_API_URL) && \
cd client && npm i && npm run build

EXPOSE 3000

CMD [ "npm", "run", "start" ]