package com.infosec.lab1.controller;

import com.infosec.lab1.dto.DataItem;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Arrays;
import java.util.List;

@RestController
@RequestMapping("/api")
public class DataController {

    private static final List<DataItem> ITEMS = Arrays.asList(
            new DataItem(1L, "Security Report Q1", "Quarterly security assessment results"),
            new DataItem(2L, "Vulnerability Scan", "Latest vulnerability scan report"),
            new DataItem(3L, "Access Logs", "User access logs for March 2026")
    );

    @GetMapping("/data")
    public ResponseEntity<List<DataItem>> getData(Authentication authentication) {
        return ResponseEntity.ok(ITEMS);
    }
}