FROM python:3.9-alpine as dependencies

RUN python -m pip install jsonschema json-schema-for-humans


FROM dependencies as sources
WORKDIR /
COPY ./schema /schema


FROM sources as validate
ENTRYPOINT ["jsonschema", "/schema/component.schema.json", "--base-uri", "file:///schema/component.schema.json", "--instance"]


FROM sources as generate-docs
RUN mkdir -p /html && generate-schema-doc /schema /html


FROM generate-docs as serve-html
WORKDIR /html
CMD python -m http.server
