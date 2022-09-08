#!/bin/bash

echo "let appSecrets = AppSecrets(username: \"$APP_USERNAME\", secret: \"$APP_SECRET\")" > ../Shared/Backend/AppSecrets.swift
