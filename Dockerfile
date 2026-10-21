# Imagen oficial de SWI-Prolog
FROM swipl:stable

WORKDIR /app
COPY base_conocimiento.pl servidor.pl ./
COPY public ./public

# Render (y otras plataformas) indican el puerto en la variable PORT
ENV PORT=8080
EXPOSE 8080

CMD ["swipl", "/app/servidor.pl"]
