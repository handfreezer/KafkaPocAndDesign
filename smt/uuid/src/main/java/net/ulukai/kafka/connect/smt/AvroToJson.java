package net.ulukai.kafka.connect.smt;

import org.apache.avro.Schema.Parser;
import org.apache.avro.file.DataFileStream;
import org.apache.avro.generic.GenericDatumReader;
import org.apache.avro.generic.GenericRecord;
import org.apache.avro.io.DatumReader;
import org.apache.kafka.common.config.ConfigDef;
import org.apache.kafka.connect.connector.ConnectRecord;
import org.apache.kafka.connect.data.Schema;
import org.apache.kafka.connect.transforms.Transformation;
import org.apache.kafka.connect.transforms.util.SimpleConfig;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import io.confluent.kafka.schemaregistry.client.CachedSchemaRegistryClient;
import io.confluent.kafka.schemaregistry.client.SchemaRegistryClient;
import io.confluent.kafka.schemaregistry.client.rest.exceptions.RestClientException;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.Map;

public class AvroToJson<R extends ConnectRecord<R>> implements Transformation<R> {

	private static final Logger logger = LoggerFactory.getLogger(AvroToJson.class);

	public static final String OVERVIEW_DOC =
		"Convert Value or key from Avro to Json according to SchemaRegistry ";

	private interface ConfigName {
		String UUID_FIELD_NAME = "uuid.field.name";
		String A2J_SCHEMA_URL = "a2j.schema.url";
	}

	public static final ConfigDef CONFIG_DEF = new ConfigDef()
			.define(ConfigName.UUID_FIELD_NAME, ConfigDef.Type.STRING, "uuid", ConfigDef.Importance.HIGH, "Field name for UUID")
			.define(ConfigName.A2J_SCHEMA_URL, ConfigDef.Type.STRING, "", ConfigDef.Importance.HIGH, "URL of schema registry");

	private SchemaRegistryClient schemaRegistry = null;

	@Override
	public void configure(Map<String, ?> props) {
		final SimpleConfig config = new SimpleConfig(CONFIG_DEF, props);
		
		String schemaUrl = config.getString(ConfigName.A2J_SCHEMA_URL);
		if ( 0 == schemaUrl.length() ) {
			String errorMsg = "Schema Registry Url conf is missing";
			logger.error(errorMsg);
			throw new IllegalArgumentException(errorMsg);
		}
		logger.info("Schema Registry Url is " + schemaUrl);
		this.schemaRegistry = new CachedSchemaRegistryClient(schemaUrl, 100);
	}

	public byte[] convertAvroToJson(String subject, byte[] avroBinary) {
		byte[] result = avroBinary.clone();
		
		if ( avroBinary.length <= 5 ) {
			logger.warn("avro binary is too small (less then 5 bytes");
		} else {
			if ( 0 != avroBinary[0] ) {
				logger.warn("avro binary doens't start with byte(0)");
			} else {
				int schemaId = ((avroBinary[1] & 0xFF) << 24) |
						((avroBinary[2] & 0xFF) << 16) |
						((avroBinary[3] & 0xFF) << 8) |
						(avroBinary[1] & 0xFF);
				try {
					org.apache.avro.Schema schema = new Parser().parse(this.schemaRegistry.getSchemaById(schemaId).toString());
					DatumReader<GenericRecord> datumReader = new GenericDatumReader<GenericRecord>(schema);
					DataFileStream<GenericRecord> dataFileReader = new DataFileStream<GenericRecord>(new ByteArrayInputStream(avroBinary), datumReader);
					GenericRecord json = null;
					String output = "";
					while (dataFileReader.hasNext()) {
						json = dataFileReader.next(json);
						output += json.toString();
					}
					result = output.getBytes();
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch (RestClientException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				
			}
		}
		return result;
	}

	@Override
	public R apply(R record) {
		R result = null;
		if ( ! record.valueSchema().equals(Schema.BYTES_SCHEMA)) {
			logger.warn("Schema of value is not BYTES, so no conversion! [valueSchema = " + record.valueSchema().toString() + " ]");
			result = record;
		} else {
			byte[] byteValue = (byte[])record.value();
			byte[] jsonValue = this.convertAvroToJson("subject",  byteValue);
			logger.debug("Avro to JSON : JSON=[ " + jsonValue + " ]");
			result = record.newRecord(
					record.topic(),
					record.kafkaPartition(),
					record.keySchema(),
					record.key(),
					record.valueSchema(),
					jsonValue,
					record.timestamp(),
					record.headers());
		}
	    return result;
	}

	@Override
	public ConfigDef config() {
		return CONFIG_DEF;
	}

	@Override
	public void close() {
	}

	//is to call a specific extension of SMT for A key, A value or something else instance, by specifying your class$specific
	public static class Key<R extends ConnectRecord<R>> extends AvroToJson<R> {
		@Override
		public R apply(R record) {
			R result = record;
			if ( ! record.valueSchema().equals(Schema.BYTES_SCHEMA)) {
				logger.warn("Schema of key is not BYTES, so no conversion! [keySchema = " + record.keySchema().toString() + " ]");
				result = record;
			} else {
				byte[] byteKey = (byte[])record.key();
				byte[] jsonValue = this.convertAvroToJson("subject",  byteKey);
				logger.debug("Avro to JSON : JSON=[ " + jsonValue + " ]");
				result = record.newRecord(
						record.topic(),
						record.kafkaPartition(),
						record.keySchema(),
						jsonValue,
						record.valueSchema(),
						record.value(),
						record.timestamp(),
						record.headers());
			}
		    return result;
		}
	}

	public static class Value<R extends ConnectRecord<R>> extends AvroToJson<R> {
		@Override
		public R apply(R record) {
			R result = record;
			if ( ! record.valueSchema().equals(Schema.BYTES_SCHEMA)) {
				logger.warn("Schema of value is not BYTES, so no conversion! [valueSchema = " + record.valueSchema().toString() + " ]");
				result = record;
			} else {
				byte[] byteValue = (byte[])record.value();
				byte[] jsonValue = this.convertAvroToJson("subject",  byteValue);
				logger.debug("Avro to JSON : JSON=[ " + jsonValue + " ]");
				result = record.newRecord(
						record.topic(),
						record.kafkaPartition(),
						record.keySchema(),
						record.key(),
						record.valueSchema(),
						jsonValue,
						record.timestamp(),
						record.headers());
			}
		    return result;
		}
	}
}
