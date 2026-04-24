# 10 Creative AWS Infrastructure Combinations

## 1. Real-Time Multiplayer Game Backend
**Prompt:** Deploy a scalable real-time multiplayer game infrastructure supporting WebSocket connections, player state synchronization, leaderboard tracking, and matchmaking. Include player authentication, automated game session management, and real-time analytics dashboard.
**Services:** API Gateway (WebSocket), ElastiCache (Redis), Lambda, DynamoDB, Cognito, Kinesis, S3, CloudFront

## 2. IoT Smart Building Monitor
**Prompt:** Build an IoT platform that collects sensor data from temperature, humidity, and occupancy sensors across multiple buildings. Process streams for anomaly detection, store historical data, trigger alerts via SNS, and provide a real-time dashboard for facility managers.
**Services:** IoT Core, Kinesis, Timestream, Lambda, SNS, QuickSight, S3, CloudWatch

## 3. ML-Powered Content Moderation Pipeline
**Prompt:** Create an automated content moderation system that ingests user-uploaded images/videos, detects inappropriate content using custom ML models, stores approved content with metadata, and sends moderation decisions via webhook to external systems.
**Services:** S3, Rekognition, SageMaker, Lambda, Step Functions, SNS, DynamoDB, API Gateway

## 4. Global News Aggregation & Translation Platform
**Prompt:** Deploy a serverless news aggregator that crawls RSS feeds from 50+ international sources, translates articles using neural MT, categorizes with NLP, stores in searchable archive, and delivers personalized feeds via mobile API.
**Services:** Lambda, EventBridge, Translate, Comprehend, OpenSearch, DynamoDB, S3, API Gateway, CloudFront

## 5. E-Commerce Fraud Detection System
**Prompt:** Build a real-time fraud detection platform for e-commerce transactions that analyzes purchase patterns, calculates risk scores using ML, blocks suspicious transactions, and provides investigative tools for analysts with transaction history.
**Services:** Kinesis, SageMaker, Lambda, DynamoDB, QuickSight, SNS, Step Functions, API Gateway

## 6. Video Processing & Streaming Platform
**Prompt:** Create a video platform that ingests raw uploads, transcodes to multiple quality levels using Elastic Transcoder, generates thumbnails, streams via HLS/DASH, implements DRM protection, and provides analytics on viewer engagement.
**Services:** S3, Elemental MediaConvert, CloudFront, Elemental MediaPackage, Cognito, Lambda, CloudWatch, Athena

## 7. Multi-Region Disaster Recovery with Near-Zero RTO
**Prompt:** Architect a multi-region active-passive disaster recovery solution for a critical web application with automated failover, cross-region database replication, DNS health checks, and automated backup verification testing.
**Services:** Route 53 (Health Checks), RDS (Cross-Region Read Replicas), S3 (Cross-Region Replication), Lambda, CloudFormation, CloudWatch, DynamoDB Global Tables

## 8. Serverless Data Lake with Automatic ETL
**Prompt:** Build a data lake that ingests data from multiple sources (S3, databases, APIs), automatically crawls schemas with Glue, transforms via Spark jobs, enables SQL querying with Athena, and visualizes in BI dashboards with scheduled reports.
**Services:** S3, Glue (Crawler + ETL), Athena, Lambda, Step Functions, QuickSight, Lake Formation, EventBridge

## 9. Voice-Enabled Customer Support Bot
**Prompt:** Deploy an intelligent customer support system with voice recognition that can answer calls, transcribe speech, understand intent with NLP, query knowledge bases, and either resolve issues autonomously or route to appropriate human agents.
**Services:** Connect, Lex, Polly, Transcribe, Comprehend, Lambda, DynamoDB, S3, SNS

## 10. Real-Time Cryptocurrency Trading Analytics
**Prompt:** Build a high-frequency trading analytics platform that ingests crypto market data via WebSocket streams, calculates real-time technical indicators, stores tick data for backtesting, triggers alerts on pattern detection, and visualizes portfolio performance.
**Services:** Kinesis, Timestream, Lambda, ElastiCache (Redis), OpenSearch, QuickSight, API Gateway, Fargate (for WebSocket consumers)
