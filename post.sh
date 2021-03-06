#! /usr/bin/env bash


SOLR_URL="http://localhost:8983/solr/update"

add_docs()
{
  for file in geoblacklight/*.xml; do
    echo "Posting $f to $SOLR_URL..."
    curl $SOLR_URL --data-binary @$file -H 'Content-type:text/xml; charset=utf-8'
  done
}

optimize()
{
  curl $SOLR_URL --data-binary '<commit/>' -H 'Content-type:text/xml; charset=utf-8'
  echo "Optimizing"
  curl $SOLR_URL --data-binary '<optimize/>' -H 'Content-type:text/xml; charset=utf-8'
}

clean()
{
  echo "Clearing Solr docs"
  curl $SOLR_URL -H "Content-Type: text/xml" --data-binary '<delete><query>*:*</query></delete>'
}

clean
add_docs
optimize
