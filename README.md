# docker-manageiq
Dockerfiles for ManageIQ

Based on CentOS PostgreSQL image

# Build

```
docker build -t manageiq .
```

# Run

```
docker run -p 3000:3000 manageiq
```

Pass REPO and BRANCH to checkout out from specific repo/branch:

```
docker run -p 3001:3000 \
       -e REPO='https://github.com/bdunne/manageiq.git' \
       -e BRANCH='tree_builder_report_widgets' manageiq
```
This will run a different version on 3001 port
