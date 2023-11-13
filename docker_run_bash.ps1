docker stop medibook_auth_ms
docker rm medibook_auth_ms
docker rmi medibook_auth_ms
docker build -t medibook_auth_ms .
docker run --name medibook_auth_ms -p 3000:3000 --link medibook_auth_db:postgres -e DATABASE_URL=postgresql://postgres:1234@postgres:5432/medibook_auth_db -d medibook_auth_ms