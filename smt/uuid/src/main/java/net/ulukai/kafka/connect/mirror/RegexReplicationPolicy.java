package net.ulukai.kafka.connect.mirror;

import org.apache.kafka.connect.mirror.DefaultReplicationPolicy;

import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.regex.PatternSyntaxException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class RegexReplicationPolicy extends DefaultReplicationPolicy {

    private static final Logger logger = LoggerFactory.getLogger(RegexReplicationPolicy.class);

	private static final String REGEX_DETECT_CONFIG = "replication.policy.regex.detect";
	private static final String REGEX_REPLACE_CONFIG = "replication.policy.regex.replace";
	private Pattern patternDetect = Pattern.compile("(.*)");
	private String regexReplace = "$1";
	
	HashMap<String, String> alreadySeen = new HashMap<String, String>();
	HashMap<String, String> upstreamTopic = new HashMap<String, String>();
	
    @Override
    public void configure(Map<String, ?> props) {
    	logger.info("With {} , you can NOT change the separator.", this.getClass());
        if (props.containsKey(REGEX_REPLACE_CONFIG)) {
		    if (! props.containsKey(REGEX_DETECT_CONFIG)) {
		    	logger.error("Replace rule is defined but detect rule is not, so {} fallback to {}", this.getClass(), super.getClass());
		    } else {
	            String regexDetect = (String) props.get(REGEX_DETECT_CONFIG);
	            try {
		            this.patternDetect = Pattern.compile(regexDetect);
		            logger.info("Using regex detect rule: [{}]", regexDetect);
			        this.regexReplace = (String) props.get(REGEX_REPLACE_CONFIG);
			        logger.info("Using regex replace rule: [{}]", this.regexReplace);
	            } catch (PatternSyntaxException e) {
	            	logger.error("Detect rule is NOT a valid regex [{}] : {}", regexDetect, e.getMessage());
	            } catch (IllegalStateException e) {
	            	logger.error("Detect rule compile failed with exception: {}", e.getMessage());
	            }
            }
        }
    }

    private String transformTopic(String topic) {
    	String result = topic;
        try {
            Matcher matcher = this.patternDetect.matcher(topic);
            result = matcher.replaceAll(this.regexReplace);
        } catch (IllegalStateException e) {
        	logger.error("Replace rule failed with exception because of : " + e.getMessage());
        }
		return result;
    }
    
    public String formatRemoteTopic(String sourceClusterAlias, String topic) {
    	String key = sourceClusterAlias+topic;
    	String remoteTopicCalulated = "error_not_initialized";
    	if ( ! this.alreadySeen.containsKey(key) ) {
    		remoteTopicCalulated = sourceClusterAlias + DefaultReplicationPolicy.SEPARATOR_DEFAULT + this.transformTopic(topic);
    		this.alreadySeen.put(key,  remoteTopicCalulated);
    		this.upstreamTopic.put(remoteTopicCalulated, topic);
    		logger.info("Format remote topic from [{}|{}] to [{}]", sourceClusterAlias, topic, remoteTopicCalulated);
    	} else {
    		remoteTopicCalulated = this.alreadySeen.get(key);
    		logger.debug("Format remote topic from [{}|{}] to [{}]", sourceClusterAlias, topic, remoteTopicCalulated);
    	}
        return remoteTopicCalulated;
    }

    public String upstreamTopic(String topic) {
        return this.upstreamTopic.get(topic);
    }
}
