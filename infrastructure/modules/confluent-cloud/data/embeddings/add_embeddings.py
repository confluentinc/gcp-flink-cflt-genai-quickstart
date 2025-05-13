import json
import sys
import time

import avro.schema
from avro.datafile import DataFileReader, DataFileWriter
from avro.io import DatumReader, DatumWriter
from google import genai
from google.genai.types import EmbedContentConfig


def get_embeddings(client, str_list, task_type, chunk_size = 10):
    results = []
    for i in range(0, len(str_list), chunk_size):
        res = client.models.embed_content(
            model="text-embedding-005",
            contents=str_list[i:i + chunk_size],
            config=EmbedContentConfig(
                task_type=task_type,
                output_dimensionality=768,
            )
        )
        results.extend(res.embeddings)
        time.sleep(1.1)  # rate limiting, thanks Google
    return results



def supplement_dict(dict_list, additional_field_name, additional_field_list):
    for i in range(0, len(dict_list)):
        dict_list[i][additional_field_name] = additional_field_list[i].values


if __name__ == '__main__':
    input_file = sys.argv[1]
    json_output_file = sys.argv[2]
    avro_output_file = sys.argv[3]

    with open(input_file) as i:
        json_strings = i.readlines()

    # json_strings = json_strings[:35]

    json_objects = [json.loads(s) for s in json_strings]
    names = [o["patient_name"] for o in json_objects]

    client = genai.Client()

    retrieval_document_whole_objects = get_embeddings(client, json_strings, "RETRIEVAL_DOCUMENT")
    retrieval_document_names = get_embeddings(client, names, "RETRIEVAL_DOCUMENT")
    semantic_similarities_whole_objects = get_embeddings(client, json_strings, "SEMANTIC_SIMILARITY")
    retrieval_query_names = get_embeddings(client, names, "RETRIEVAL_QUERY")

    # combine results into json_objects
    supplement_dict(json_objects, "retrieval_document_embeddings", retrieval_document_whole_objects)
    supplement_dict(json_objects, "retrieval_document_name_embeddings", retrieval_document_names)
    supplement_dict(json_objects, "semantic_similarities_embeddings", semantic_similarities_whole_objects)
    supplement_dict(json_objects, "retrieval_query_name_embeddings", retrieval_query_names)

    with open(json_output_file, "w+") as o:
        for item in json_objects:
            json.dump(item, o)
            o.write("\n")

    print(f"Done writing {len(json_objects)} entries to {json_output_file}")

    schema = avro.schema.parse(open("./record.avsc", "r").read())

    writer = DataFileWriter(open(avro_output_file, "wb"), DatumWriter(), schema)
    for item in json_objects:
        writer.append(item)
    writer.close()

    print(f"Done writing {len(json_objects)} entries to {avro_output_file}")
