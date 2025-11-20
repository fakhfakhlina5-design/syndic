FROM node:18

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

# rendre exécutable
RUN chmod +x ./entrypoint.sh

EXPOSE 3001

CMD ["./entrypoint.sh"]
