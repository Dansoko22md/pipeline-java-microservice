package tn.esprit.monprojet.controllers;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import tn.esprit.monprojet.entities.Client;
import tn.esprit.monprojet.services.IServices;

import java.util.List;

@RequiredArgsConstructor
@RequestMapping("api")
@RestController

public class ClientRestController {

    @Autowired
    private IServices services;


    // Méthode POST pour ajouter un client
    @PostMapping("/add")
    public Client add(@RequestBody Client client) {
        return services.add(client);
    }

    // Méthode GET pour récupérer tous les clients
    @GetMapping("/clients")
    public List<Client> getAllClients() {
        return services.getAllClients();
    }

    // Méthode GET pour récupérer un client par son ID
    @GetMapping("/client/{id}")
    public Client getClientById(@PathVariable Long id) {
        return services.getClientById(id);
    }
    @DeleteMapping("/delete/{id}")
    public void deleteClient(@PathVariable Long id) {
        services.deleteClient(id);
    }

}
