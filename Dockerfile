FROM node:20-slim
WORKDIR /app
COPY docs/foundry/manifest.json ./docs/foundry/manifest.json
COPY scripts/foundry-doctor.sh ./scripts/foundry-doctor.sh
CMD ["node", "--version"]
