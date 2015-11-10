# docker-manageiq
Dockerfiles for ManageIQ

Based on CentOS PostgreSQL image

# Build

```
docker build -t manageiq .
```

# Run
Pass REPO and BRANCH to checkout out from specific repo/branch:
```
docker run -p 3000:3000 -p 4000:4000 \
       -e REPO='https://github.com/bdunne/manageiq.git' \
       -e BRANCH='tree_builder_report_widgets' manageiq
```

or leave blank to use master branch of the main repo.

After the container is up commit changes:
```
docker commit <container_id> manageiq:tree_builder_report_widgets
```

When a new container is started from this image new changes will be pulled,
DB reset and EVM is restarted
```
docker run -p 3000:3000 -p 4000:4000 manageiq:tree_builder_report_widgets
```