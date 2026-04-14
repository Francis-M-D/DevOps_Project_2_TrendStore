FROM nginx:alpine

# Remove default nginx static files
RUN rm -rf /usr/share/nginx/html/*

# Copy dist files
COPY dist/ /usr/share/nginx/html/

# Expose port
EXPOSE 3000

# Modify nginx to run on port 3000
RUN sed -i 's/listen       80;/listen 3000;/' /etc/nginx/conf.d/default.conf

CMD ["nginx", "-g", "daemon off;"]
