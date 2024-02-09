package net.ulukai.kafka.connect.smt;

import org.apache.kafka.common.config.ConfigDef;
import org.apache.kafka.connect.connector.ConnectRecord;
import org.apache.kafka.connect.header.Headers;
import org.apache.kafka.connect.transforms.Transformation;
import org.apache.kafka.connect.transforms.util.SimpleConfig;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Map;
import java.util.UUID;

// this declaration in case of subclass instance needed
// public abstract class AddUuid<R extends ConnectRecord<R>> implements Transformation<R> {
public class AddUuid<R extends ConnectRecord<R>> implements Transformation<R> {

	private static final Logger log = LoggerFactory.getLogger(AddUuid.class);

	public static final String OVERVIEW_DOC =
		"Insert a random UUID into a connect record ";

	private interface ConfigName {
		String UUID_FIELD_NAME = "uuid.field.name";
	}

	public static final ConfigDef CONFIG_DEF = new ConfigDef()
		.define(ConfigName.UUID_FIELD_NAME, ConfigDef.Type.STRING, "uuid", ConfigDef.Importance.HIGH,
				"Field name for UUID");

//	private static final String PURPOSE = "adding UUID to record";

	private String fieldName;

	@Override
	public void configure(Map<String, ?> props) {
		final SimpleConfig config = new SimpleConfig(CONFIG_DEF, props);
		this.fieldName = config.getString(ConfigName.UUID_FIELD_NAME);
		AddUuid.log.info("Field name value is " + this.fieldName);
	}


	@Override
	public R apply(R record) {
		Headers newHeaders = record.headers().duplicate();
		String uuid = getRandomUuid();
		newHeaders.addString(this.fieldName, uuid);
		AddUuid.log.debug("Adding uuid[" + uuid + "] to a message in topic " + record.topic() + " into field name ending with " +  this.fieldName);
		return record.newRecord(record.topic(),
				record.kafkaPartition(),
				record.keySchema(),
				record.key(),
				record.valueSchema(),
				record.value(),
				record.timestamp(),
				newHeaders);
	}

	@Override
	public ConfigDef config() {
		return CONFIG_DEF;
	}

	@Override
	public void close() {
	}

	private String getRandomUuid() {
		return UUID.randomUUID().toString();
	}

	//is to call a specific extension of SMT for A key, A value or something else instance, by specifying your class$specific
	public static class Key<R extends ConnectRecord<R>> extends AddUuid<R> {
	}

	public static class Value<R extends ConnectRecord<R>> extends AddUuid<R> {
	}
}
