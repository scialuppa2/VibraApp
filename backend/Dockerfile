# Usa l'immagine base di Node.js con Alpine
FROM node:16-alpine

# Crea la directory di lavoro e imposta i permessi per l'utente node
RUN mkdir -p /node/app/node_modules && chown -R node:node /node/app

# Imposta la directory di lavoro
WORKDIR /node/app

# Copia i file di dipendenza con permessi appropriati
COPY --chown=node:node package*.json ./

# Installa le dipendenze come utente node
USER node

# Installa le dipendenze
RUN npm install

# Copia il resto dell'applicazione con permessi appropriati
COPY --chown=node:node . .

# Esponi la porta su cui l'applicazione sarà in ascolto
EXPOSE 3000

# Comando per avviare l'applicazione
CMD ["node", "app.js"]
